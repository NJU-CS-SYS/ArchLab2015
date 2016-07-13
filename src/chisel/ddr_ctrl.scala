import Chisel._

class DDRControlModule extends Module {
  val io = new Bundle {
    val init_calib_complete = Bool(INPUT)
    val mig_data_valid = Bool(INPUT)
    val mig_rdy = Bool(INPUT)
    val mig_wdf_rdy = Bool(INPUT)
    val data_from_mig = UInt(INPUT, 128)

    val ram_en = Bool(INPUT)
    val ram_write = Bool(INPUT)
    val ram_addr = UInt(INPUT, 30)
    val data_to_ram = UInt(INPUT, 256)

    val cmd_to_mig = UInt(OUTPUT, 3)
    val app_en = Bool(OUTPUT)
    val ram_rdy = Bool(OUTPUT)

    val app_wdf_wren = Bool(OUTPUT)
    val app_wdf_end = Bool(OUTPUT)

    val addr_to_mig = UInt(OUTPUT, 27)
    val data_to_mig = UInt(OUTPUT, 128)
    val data_to_cpu = UInt(OUTPUT, 256)
    val state_to_cpu = UInt(OUTPUT, 4)
  }
  val (idle ::
    w1req :: w1wait ::
    w2req :: w2wait ::
    r1req_1 :: r1wait_1 ::
    r1req_2 :: r1wait_2 ::
    r2req_1 :: r2wait_1 ::
    r2req_2 :: r2wait_2 ::
    finish :: Nil)
  = Enum(UInt(), 14)
  val state = Reg(init = idle)
  val counter = Reg(init = UInt(0, 6))
  val buffer = Reg(init = UInt(0, 256))
  val buffer_old = Reg(init = UInt(0, 256))

  val ram_addr_old = Reg(init = UInt(0, 22))
  val ram_write_old = Reg(init = UInt(0, 1))

  io.cmd_to_mig := UInt(1)
  io.app_en := UInt(0)
  io.ram_rdy := UInt(0)
  io.data_to_mig := UInt(0)
  io.addr_to_mig := UInt(0)
  io.app_wdf_wren := UInt(0);
  io.app_wdf_end := UInt(0);

  val not_move = ((state === idle & io.ram_en === UInt(0))
    | ((state === idle) & (ram_addr_old === io.ram_addr(25,3)) &
      (ram_write_old === io.ram_write)))

  val true_ = Bool(true)
  val false_ = Bool(false)
  val recorded_neg = Reg(init = Bool(false))

  val read_wait_cyle = UInt(4, 6)
  val write_wait_cyle = UInt(3, 6)
  val one_cycle = UInt(1, 6)
  val zero_cyle = UInt(0, 6)

  when (io.init_calib_complete) {
    counter := counter + UInt(1)
    when (state === idle) {
      when (~not_move) {
        counter := zero_cyle
        recorded_neg := false_
        when (io.ram_en & ~io.ram_write) { state := r1req_1 }
        when (io.ram_en & io.ram_write) { state := w1req }
      }
    }
    when (state === w1req) {
      io.cmd_to_mig := UInt(0)
      io.app_en := UInt(1)
      io.app_wdf_wren := UInt(1);
      io.app_wdf_end := UInt(1);
      io.addr_to_mig := Cat(io.ram_addr(25, 3), UInt(0, 5))
      io.data_to_mig := io.data_to_ram(127, 0)
      counter := counter + one_cycle
      when (~io.mig_rdy) {
        recorded_neg := true_
      }
      when (io.mig_rdy & io.mig_wdf_rdy & counter >= write_wait_cyle
        & recorded_neg) {
        state := w1wait
        counter := zero_cyle
      }
    }
    when (state === w1wait) {
      counter := counter + one_cycle
      when (io.mig_rdy & counter >= write_wait_cyle) {
        state := w2req
        counter := zero_cyle
        recorded_neg := false_
      }
    }

    when (state === w2req) {
      io.cmd_to_mig := UInt(0)
      io.app_en := UInt(1)
      io.app_wdf_wren := UInt(1);
      io.app_wdf_end := UInt(1);
      io.addr_to_mig := Cat(io.ram_addr(25, 3), UInt(16, 5))
      io.data_to_mig := io.data_to_ram(255, 128)
      counter := counter + one_cycle
      when (~io.mig_rdy) {
        recorded_neg := true_
      }
      when (io.mig_rdy & io.mig_wdf_rdy & counter >= write_wait_cyle
        & recorded_neg) {
        state := w2wait
        counter := zero_cyle
      }
    }

    when (state === w2wait) {
      counter := counter + one_cycle
      when (io.mig_rdy & counter >= write_wait_cyle) {
        state := finish
      }
    }

    when (state === r1req_1) {
      io.app_en := UInt(1)
      io.addr_to_mig := Cat(io.ram_addr(25, 3), UInt(0, 5))
      counter := counter + one_cycle
      when (~io.mig_rdy) {
        recorded_neg := true_
      }
      when (io.mig_rdy & counter >= one_cycle & recorded_neg) {
        state := r1wait_1
        counter := zero_cyle
      }
    }
    when (state === r1wait_1) {
      counter := counter + one_cycle
      when (io.mig_data_valid & counter >= read_wait_cyle) {
        state := r1req_2
        buffer_old(127, 0) := io.data_from_mig
        counter := zero_cyle
        recorded_neg := false_
      }
      when (~io.mig_data_valid & counter >= UInt(60)) {
        state := r1req_1
        counter := zero_cyle
        recorded_neg := false_
      }
    }

    when (state === r1req_2) {
      io.app_en := UInt(1)
      io.addr_to_mig := Cat(io.ram_addr(25, 3), UInt(0, 5))
      counter := counter + one_cycle
      when (~io.mig_rdy) {
        recorded_neg := true_
      }
      when (io.mig_rdy & counter >= one_cycle & recorded_neg) {
        state := r1wait_2
        counter := zero_cyle
      }
    }
    when (state === r1wait_2) {
      counter := counter + one_cycle
      when (io.mig_data_valid & counter >= read_wait_cyle) {
        state := r2req_1
        buffer(127, 0) := io.data_from_mig
        counter := zero_cyle
        recorded_neg := false_
        when (io.data_from_mig =/= buffer_old(127, 0)) {
          state := r1req_1
        }
      }
      when (~io.mig_data_valid & counter >= UInt(60)) {
        state := r1req_2
        counter := zero_cyle
        recorded_neg := false_
      }
    }

    when (state === r2req_1) {
      io.app_en := UInt(1)
      io.addr_to_mig := Cat(io.ram_addr(25, 3), UInt(16, 5))
      counter := counter + one_cycle
      when (~io.mig_rdy) {
        recorded_neg := true_
      }
      when (io.mig_rdy & counter >= one_cycle & recorded_neg) {
        state := r2wait_1
        counter := zero_cyle
      }
    }
    when (state === r2wait_1) {
      counter := counter + one_cycle
      when (io.mig_data_valid & counter >= read_wait_cyle) {
        state := r2req_2
        buffer_old(127, 0) := io.data_from_mig
        counter := zero_cyle
        recorded_neg := false_
      }
      when (~io.mig_data_valid & counter >= UInt(60)) {
        state := r2req_1
        counter := zero_cyle
        recorded_neg := false_
      }
    }

    when (state === r2req_2) {
      io.app_en := UInt(1)
      io.addr_to_mig := Cat(io.ram_addr(25, 3), UInt(16, 5))
      counter := counter + one_cycle
      when (~io.mig_rdy) {
        recorded_neg := true_
      }
      when (io.mig_rdy & counter >= one_cycle & recorded_neg) {
        state := r2wait_2
        counter := zero_cyle
      }
    }
    when (state === r2wait_2) {
      counter := counter + one_cycle
      when (io.mig_data_valid & counter >= read_wait_cyle) {
        state := finish
        buffer(255, 128) := io.data_from_mig
        recorded_neg := false_
        when (io.data_from_mig =/= buffer_old(127, 0)) {
          state := r2req_1
        }
      }
      when (~io.mig_data_valid & counter >= UInt(60)) {
        state := r2req_2
        counter := zero_cyle
        recorded_neg := false_
      }
    }

    when (state === finish) {
      state := idle
      ram_addr_old := io.ram_addr(25,3)
      ram_write_old := io.ram_write
    }
  }

  io.ram_rdy := not_move | (state === finish)
  /* | (state === finish)*/
  io.data_to_cpu := buffer
  io.state_to_cpu := state
}

class HelloModuleTests(c: DDRControlModule) extends Tester(c) {
  step(1)
}

object hello {
  def main(args: Array[String]): Unit = {
    chiselMainTest(Array[String]("--backend", "v", "--genHarness"),
      () => Module(new DDRControlModule())){c => new HelloModuleTests(c)}
  }
}
